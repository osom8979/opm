#!/usr/bin/env bash
#
# Create the read-only account that unwiki (mwfilter) uses to download pages,
# then print its '.env.local' settings and account management pages.
# Running it again for the same account issues a new password.
#
# Usage: ./create-readonly-bot.sh [username]   (default: UnwikiBot)

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
# shellcheck source=common.sh
source "$ROOT_DIR/common.sh"

if [[ $# -gt 1 || $1 == -h || $1 == --help ]]; then
    echo "Usage: $0 [username]   (default: UnwikiBot)"
    exit 1
fi

BOT_USERNAME=${1:-UnwikiBot}

if ! is_running mariadb; then
    print_error "The 'mariadb' service is not running"
    exit 1
fi

# The maintenance class goes through stdin so that this script stays a single file.
# The password is generated inside the container and never appears in 'ps'.
# shellcheck disable=SC2016
compose run --rm --no-deps -T --user www-data mediawiki sh -c '
    cat > /tmp/create-readonly-bot.php || exit
    exec php maintenance/run.php /tmp/create-readonly-bot.php "$@"
' create-readonly-bot "$BOT_USERNAME" << 'PHP'
<?php

use MediaWiki\Auth\AuthManager;
use MediaWiki\Deferred\SiteStatsUpdate;
use MediaWiki\Extension\OATHAuth\OATHAuthServices;
use MediaWiki\MainConfigNames;
use MediaWiki\Session\SessionManager;
use MediaWiki\User\User;

class CreateReadonlyBot extends Maintenance {
	private const GROUP = 'readonly';

	// mwfilter only reads pages, revisions, site info and file URLs
	private const ALLOWED_RIGHTS = [ 'read' ];

	public function __construct() {
		parent::__construct();
		$this->addDescription( 'Create the read-only account for unwiki, or reset its password' );
		$this->addArg( 'username', 'Name of the read-only account' );
	}

	public function execute() {
		$services = $this->getServiceContainer();

		$this->checkGroupConfig();

		$user = $services->getUserFactory()->newFromName( $this->getArg( 0 ) );
		if ( !$user ) {
			$this->fatalError( "Invalid username: '{$this->getArg( 0 )}'" );
		}

		$exists = $user->isRegistered();
		if ( $exists ) {
			$this->checkExistingUser( $user );
		} else {
			// Same steps as maintenance/createAndPromote.php
			$status = $services->getAuthManager()->autoCreateUser(
				$user,
				AuthManager::AUTOCREATE_SOURCE_MAINT,
				false
			);
			if ( !$status->isGood() ) {
				$this->fatalError( $status );
			}
			SiteStatsUpdate::factory( [ 'users' => 1 ] )->doUpdate();
			$services->getUserGroupManager()->addUserToGroup( $user, self::GROUP );
			$this->addRightsLogEntry( $user );
		}

		// Check what MediaWiki actually grants before the account can log in
		$this->checkUserRights( $user );

		$password = bin2hex( random_bytes( 20 ) );
		$status = $user->changeAuthenticationData( [
			'username' => $user->getName(),
			'password' => $password,
			'retype' => $password,
		] );
		if ( !$status->isGood() ) {
			$this->fatalError( 'Setting the password failed: ' . $status->getMessage( false, false, 'en' )->text() );
		}

		// Log out the sessions that used the previous password. The web server keeps
		// the user (and its token) in its own APCu cache, which this container cannot
		// purge, so the change reaches it when that cache expires (up to an hour).
		SessionManager::singleton()->invalidateSessionsForUser( $user );

		$this->printReport( $user, $password, $exists );
	}

	private function checkGroupConfig(): void {
		$groupManager = $this->getServiceContainer()->getUserGroupManager();
		$memberGroups = array_merge( $groupManager->listAllImplicitGroups(), [ self::GROUP ] );
		$rights = $this->getServiceContainer()->getGroupPermissionsLookup()->getGroupPermissions( $memberGroups );

		$defined = in_array( self::GROUP, $groupManager->listAllGroups(), true );
		$extra = array_diff( $rights, self::ALLOWED_RIGHTS );
		$missing = array_diff( self::ALLOWED_RIGHTS, $rights );
		if ( $defined && !$extra && !$missing ) {
			return;
		}

		$this->error( "The '" . self::GROUP . "' group is not read-only in LocalSettings.php" );
		if ( !$defined ) {
			$this->error( ' - The group is not defined' );
		}
		if ( $extra ) {
			$this->error( ' - Members still get: ' . implode( ', ', $extra ) );
		}
		if ( $missing ) {
			$this->error( ' - Members do not get: ' . implode( ', ', $missing ) );
		}
		$this->fatalError(
			"Copy the 'Read-only accounts' block of init.php to the end of LocalSettings.php,\n" .
			"and add the rights listed above to \$wgRevokePermissions['" . self::GROUP . "'] if any remain."
		);
	}

	private function checkExistingUser( User $user ): void {
		$groups = $this->getServiceContainer()->getUserGroupManager()->getUserGroups( $user );
		$name = $user->getName();

		// Never reset the password of a person's account
		if ( !in_array( self::GROUP, $groups, true ) ) {
			$this->fatalError( "'$name' exists but is not in the '" . self::GROUP . "' group. Choose another username." );
		}
		$others = array_diff( $groups, [ self::GROUP ] );
		if ( $others ) {
			$this->fatalError( "'$name' is also in these groups: " . implode( ', ', $others ) . '. Remove them first.' );
		}

		if ( class_exists( OATHAuthServices::class )
			&& OATHAuthServices::getInstance()->getUserRepository()->findByUser( $user )->isTwoFactorAuthEnabled()
		) {
			$this->fatalError(
				"'$name' has two-factor authentication, so mwfilter cannot log in through the API.\n" .
				"Disable it first: php extensions/OATHAuth/maintenance/disableOATHAuthForUser.php '$name'"
			);
		}
	}

	private function checkUserRights( User $user ): void {
		$permissionManager = $this->getServiceContainer()->getPermissionManager();
		$permissionManager->invalidateUsersRightsCache( $user );
		$extra = array_diff( $permissionManager->getUserPermissions( $user ), self::ALLOWED_RIGHTS );
		if ( $extra ) {
			$this->fatalError(
				"'{$user->getName()}' still gets these rights: " . implode( ', ', $extra ) . "\n" .
				"Add them to \$wgRevokePermissions['" . self::GROUP . "'] in LocalSettings.php. The password was not set."
			);
		}
	}

	private function addRightsLogEntry( User $user ): void {
		$logEntry = new ManualLogEntry( 'rights', 'rights' );
		$logEntry->setPerformer( User::newSystemUser( User::MAINTENANCE_SCRIPT_USER, [ 'steal' => true ] ) );
		$logEntry->setTarget( $user->getUserPage() );
		$logEntry->setComment( 'Read-only account for unwiki (create-readonly-bot.sh)' );
		$logEntry->setParameters( [
			'4::oldgroups' => [],
			'5::newgroups' => [ self::GROUP ],
		] );
		$logEntry->publish( $logEntry->insert() );
	}

	private function printReport( User $user, string $password, bool $exists ): void {
		$config = $this->getConfig();
		$server = $config->get( MainConfigNames::CanonicalServer );
		$articlePath = $config->get( MainConfigNames::ArticlePath );
		$hostname = parse_url( $server, PHP_URL_HOST );
		$port = parse_url( $server, PHP_URL_PORT );
		if ( $port ) {
			$hostname .= ":$port";
		}
		$name = $user->getName();
		$page = static function ( string $title, string $query = '' ) use ( $server, $articlePath ) {
			return $server . str_replace( '$1', wfUrlencode( $title ), $articlePath ) . $query;
		};

		$rights = implode( ', ', self::ALLOWED_RIGHTS );
		if ( $exists ) {
			$this->output( "Issued a new password for '$name' (rights: $rights). The old one no longer works.\n" );
			$this->output( "If the account logged in during the last hour, the web server may cache its old\n" );
			$this->output( "token for up to an hour. Until then, old sessions keep working and new logins are\n" );
			$this->output( "dropped after the first request. To apply it now, run 'docker compose restart mediawiki'\n" );
			$this->output( "(this logs out everyone).\n" );
		} else {
			$this->output( "Created read-only account '$name' (rights: $rights).\n" );
		}

		$this->output( "\nAdd the following to unwiki's .env.local:\n\n" );
		$this->output( "MEDIAWIKI_HOSTNAME=$hostname\n" );
		$this->output( "MEDIAWIKI_USERNAME=$name\n" );
		$this->output( "MEDIAWIKI_PASSWORD=$password\n" );
		// mwfilter defaults to '/w/', but api.php lives under $wgScriptPath
		$this->output( 'ENDPOINT_PATH=' . $config->get( MainConfigNames::ScriptPath ) . "/\n" );

		$this->output( "\nAccount management (log in as an administrator):\n" );
		$this->output( ' - Groups       : ' . $page( "Special:UserRights/$name" ) . "\n" );
		$this->output( ' - Group rights : ' . $page( 'Special:ListGroupRights' ) . "\n" );
		$this->output( ' - Members      : ' . $page( 'Special:ListUsers/' . self::GROUP ) . "\n" );
		$this->output( ' - Edits        : ' . $page( "Special:Contributions/$name" ) . "\n" );
		$this->output( ' - Logs         : ' . $page( 'Special:Log', '?page=' . wfUrlencode( "User:$name" ) ) . "\n" );

		$this->output( "\nNotes:\n" );
		$this->output( " - The password is shown only once. Run this script again to replace it.\n" );
		$this->output( " - Keep the account in the '" . self::GROUP . "' group. Without it, it gets normal user rights.\n" );
		$this->output( " - Blocking does not stop reading. To cut off a leaked password, run this script again.\n" );
	}
}

return CreateReadonlyBot::class;
PHP
