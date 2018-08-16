external_url 'http://@FRONTEND_HOST@/'
gitlab_rails['initial_root_password'] = File.read('/run/secrets/gitlab-root-pw')

