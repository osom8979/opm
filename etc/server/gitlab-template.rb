external_url 'http://@FRONTEND_HOST@/'

## An open source Git extension for versioning large files
gitlab_rails['lfs_enabled'] = true

## SMTP without SSL (Use the MailHog)
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = 'mailhog_api';
gitlab_rails['smtp_port'] = 1025;
gitlab_rails['smtp_domain'] = 'mailhog_api';
gitlab_rails['smtp_tls'] = false;
gitlab_rails['smtp_openssl_verify_mode'] = 'none'
gitlab_rails['smtp_enable_starttls_auto'] = false
gitlab_rails['smtp_ssl'] = false
gitlab_rails['smtp_force_ssl'] = false

# If your SMTP server does not like the default 'From: gitlab@localhost' you
# can change the 'From' with this setting.
gitlab_rails['gitlab_email_from'] = 'gitlab@localhost'
gitlab_rails['gitlab_email_reply_to'] = 'noreply@localhost'

