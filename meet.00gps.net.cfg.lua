-- /etc/prosody/conf.d/meet-loc1.00gps.net.cfg.lua

plugin_paths = { "/usr/share/jitsi-meet/prosody-plugins/" }

-- domain mapper options, must at least have domain base set to use the mapper
muc_mapper_domain_base = "meet-loc1.00gps.net";

external_service_secret = "g2ppxTQ0VZ8DYDAR";
external_services = {
     { type = "stun", host = "meet-loc1.00gps.net", port = 3478 },
     { type = "turn", host = "meet-loc1.00gps.net", port = 3478, transport = "udp", secret = true, ttl = 86400, algorithm = "turn" },
     { type = "turns", host = "meet-loc1.00gps.net", port = 5349, transport = "tcp", secret = true, ttl = 86400, algorithm = "turn" }
};

cross_domain_bosh = false;
consider_bosh_secure = true;
-- https_ports = { }; -- Remove this line to prevent listening on port 5284

-- https://ssl-config.mozilla.org/#server=haproxy&version=2.1&config=intermediate&openssl=1.1.0g&guideline=5.4
ssl = {
    protocol = "tlsv1_2+";
    ciphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
}

VirtualHost "meet-loc1.00gps.net"
    -- enabled = false -- Remove this line to enable this host
    authentication = "anonymous"
    -- Properties below are modified by jitsi-meet-tokens package config
    -- and authentication above is switched to "token"
    --app_id="example_app_id"
    --app_secret="example_app_secret"
    -- Assign this host a certificate for TLS, otherwise it would use the one
    -- set in the global section (if any).
    -- Note that old-style SSL on port 5223 only supports one certificate, and will always
    -- use the global one.
    ssl = {
        key = "/etc/prosody/certs/meet-loc1.00gps.net.key";
        certificate = "/etc/prosody/certs/meet-loc1.00gps.net.crt";
    }
    speakerstats_component = "speakerstats.meet-loc1.00gps.net"
    conference_duration_component = "conferenceduration.meet-loc1.00gps.net"
    -- we need bosh
    modules_enabled = {
        "bosh";
        "pubsub";
        "ping"; -- Enable mod_ping
        "speakerstats";
        "external_services";
        "conference_duration";
        "muc_lobby_rooms";
    }
    c2s_require_encryption = false
    lobby_muc = "lobby.meet-loc1.00gps.net"
    main_muc = "conference.meet-loc1.00gps.net"
    -- muc_lobby_whitelist = { "recorder.meet-loc1.00gps.net" } -- Here we can whitelist jibri to enter lobby enabled rooms

Component "conference.meet-loc1.00gps.net" "muc"
    storage = "memory"
    modules_enabled = {
        "muc_meeting_id";
        "muc_domain_mapper";
        --"token_verification";
    }
    admins = { "focus@auth.meet-loc1.00gps.net" }
    muc_room_locking = false
    muc_room_default_public_jids = true

-- internal muc component
Component "internal.auth.meet-loc1.00gps.net" "muc"
    storage = "memory"
    modules_enabled = {
        "ping";
    }
    admins = { "focus@auth.meet-loc1.00gps.net", "jvb@auth.meet-loc1.00gps.net" }
    muc_room_locking = false
    muc_room_default_public_jids = true

VirtualHost "auth.meet-loc1.00gps.net"
    ssl = {
        key = "/etc/prosody/certs/auth.meet-loc1.00gps.net.key";
        certificate = "/etc/prosody/certs/auth.meet-loc1.00gps.net.crt";
    }
    authentication = "internal_hashed"

-- Proxy to jicofo's user JID, so that it doesn't have to register as a component.
Component "focus.meet-loc1.00gps.net" "client_proxy"
    target_address = "focus@auth.meet-loc1.00gps.net"

Component "speakerstats.meet-loc1.00gps.net" "speakerstats_component"
    muc_component = "conference.meet-loc1.00gps.net"

Component "conferenceduration.meet-loc1.00gps.net" "conference_duration_component"
    muc_component = "conference.meet-loc1.00gps.net"

Component "lobby.meet-loc1.00gps.net" "muc"
    storage = "memory"
    restrict_room_creation = true
    muc_room_locking = false
    muc_room_default_public_jids = true
