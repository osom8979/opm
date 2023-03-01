FRONTEND_HOST = "https://@FRONTEND_HOST@/"
PORTAL_NAME = 'Media Blackhole'
SECRET_KEY = 'ma!s3^b-cw!f#7s6s0m3*jx77a@riw(7701**(r=ww%w!2+yk2'
POSTGRES_HOST = 'db'
REDIS_LOCATION = "redis://redis:6379/1"

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "mediacms",
        "HOST": POSTGRES_HOST,
        "PORT": "5432",
        "USER": "mediacms",
        "PASSWORD": "mediacms",
    }
}

CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": REDIS_LOCATION,
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
        },
    }
}

# CELERY STUFF
BROKER_URL = REDIS_LOCATION
CELERY_RESULT_BACKEND = BROKER_URL

MP4HLS_COMMAND = (
    "/home/mediacms.io/bento4/bin/mp4hls"
)

DEBUG = False

# who can add media
CAN_ADD_MEDIA = "advancedUser"

# what is the portal workflow
PORTAL_WORKFLOW = "private"

# show/hide the Sign in button
# LOGIN_ALLOWED = False

# show/hide the Register button
# REGISTER_ALLOWED = False

# show/hide the upload media button
# UPLOAD_MEDIA_ALLOWED = False

# show/hide the actions buttons (like/dislike/report)
# CAN_LIKE_MEDIA = True  # whether the like media appears
# CAN_DISLIKE_MEDIA = True  # whether the dislike media appears
# CAN_REPORT_MEDIA = True  # whether the report media appears
# CAN_SHARE_MEDIA = True  # whether the share media appears

# set email settings
DEFAULT_FROM_EMAIL = 'localhsot@mediacms.io'
# EMAIL_HOST_PASSWORD = ''
# EMAIL_HOST_USER = ''
EMAIL_USE_TLS = False
SERVER_EMAIL = DEFAULT_FROM_EMAIL
EMAIL_HOST = 'postfix_api'
EMAIL_PORT = 25
ADMIN_EMAIL_LIST = ['@ADMIN_EMAIL@']

# specify maximum number of media for a playlist
MAX_MEDIA_PER_PLAYLIST = 1000

# specify maximum size of a media that can be uploaded
UPLOAD_MAX_SIZE = 1024 * 1024 * 1024 * 12

# disallow user registration
USERS_CAN_SELF_REGISTER = False

