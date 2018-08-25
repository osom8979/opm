external_url 'http://@FRONTEND_HOST@/'

## An open source Git extension for versioning large files
gitlab_rails['lfs_enabled'] = true

## SMTP without SSL (Use the Postfix)
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = 'postfix_api';
gitlab_rails['smtp_port'] = 25;
gitlab_rails['smtp_domain'] = 'postfix_api';
gitlab_rails['smtp_tls'] = false;
gitlab_rails['smtp_openssl_verify_mode'] = 'none'
gitlab_rails['smtp_enable_starttls_auto'] = false
gitlab_rails['smtp_ssl'] = false
gitlab_rails['smtp_force_ssl'] = false

# If your SMTP server does not like the default 'From: gitlab@localhost' you
# can change the 'From' with this setting.
gitlab_rails['gitlab_email_from'] = 'gitlab@@FRONTEND_HOST@'
gitlab_rails['gitlab_email_reply_to'] = 'noreply@@FRONTEND_HOST@'

