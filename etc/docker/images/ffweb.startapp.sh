# #!/usr/bin/with-contenv sh
#
# set -e # Exit immediately if a command exits with a non-zero status.
# set -u # Treat unset variables as an error.

export HOME=/config
export PROFILE_DIR=$HOME/profile

export OUTPUT_LOG=$HOME/log/firefox/output.log
export ERROR_LOG=$HOME/log/firefox/error.log

mkdir -p "$PROFILE_DIR"

# 동영상 캡처 프록시 (mitmproxy + /ffcap.py)
USER_JS=$PROFILE_DIR/user.js
touch "$USER_JS"
sed -i '/\/\/ ffcap-begin/,/\/\/ ffcap-end/d' "$USER_JS"

if [ "${FFCAP_ENABLE:-0}" = "1" ]; then
    MITM_CONF_DIR=$HOME/.mitmproxy
    MITM_LOG=$HOME/log/firefox/mitmproxy.log
    mkdir -p "$MITM_CONF_DIR" "$FFCAP_DIR"

    mitmdump \
        --listen-host 127.0.0.1 \
        --listen-port "$FFCAP_PORT" \
        --set confdir="$MITM_CONF_DIR" \
        --set termlog_verbosity=warn \
        --set flow_detail=0 \
        -s /ffcap.py \
        >> "$MITM_LOG" 2>&1 &

    # Firefox 정책(policies.json)이 이 인증서를 설치하므로 생성될 때까지 대기
    for _ in $(seq 50); do
        [ -f "$MITM_CONF_DIR/mitmproxy-ca-cert.pem" ] && break
        sleep 0.1
    done

    cat >> "$USER_JS" <<END
// ffcap-begin
user_pref("network.proxy.type", 1);
user_pref("network.proxy.http", "127.0.0.1");
user_pref("network.proxy.http_port", $FFCAP_PORT);
user_pref("network.proxy.ssl", "127.0.0.1");
user_pref("network.proxy.ssl_port", $FFCAP_PORT);
user_pref("network.proxy.share_proxy_settings", true);
user_pref("network.trr.mode", 5);
// ffcap-end
END
else
    cat >> "$USER_JS" <<END
// ffcap-begin
user_pref("network.proxy.type", 0);
// ffcap-end
END
fi

firefox --version

# "$@": /etc/services.d/app/params (--profile, FF_KIOSK, FF_CUSTOM_ARGS, FF_OPEN_URL)
exec /usr/bin/firefox "$@" \
    >> "$OUTPUT_LOG" \
    2>> "$ERROR_LOG"
