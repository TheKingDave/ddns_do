# Got from: https://github.com/dart-lang/sdk/issues/39296#issuecomment-629694141
FROM google/dart AS dart-runtime
WORKDIR /app
ADD pubspec.* /app/
RUN pub get
ADD bin /app/bin
ADD lib /app/lib
RUN pub get --offline
RUN dart2native bin/ddns_do.dart -o bin/ddns_do_linux

FROM scratch

# For name-service order configuration, predefined hostnames like "localhost", dns server IPs
COPY --from=dart-runtime /etc/nsswitch.conf /etc/nsswitch.conf
COPY --from=dart-runtime /etc/hosts /etc/hosts
COPY --from=dart-runtime /etc/resolv.conf /etc/resolv.conf

# For performing the actual DNS queries to DNS servers
COPY --from=dart-runtime /lib/x86_64-linux-gnu/libnss_dns.so.2 /lib/x86_64-linux-gnu/libnss_dns.so.2
COPY --from=dart-runtime /lib/x86_64-linux-gnu/libresolv.so.2 /lib/x86_64-linux-gnu/libresolv.so.2

# Copy required binaries
COPY --from=dart-runtime /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
COPY --from=dart-runtime /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
COPY --from=dart-runtime /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/libm.so.6
COPY --from=dart-runtime /lib/x86_64-linux-gnu/libpthread.so.0 /lib/x86_64-linux-gnu/libpthread.so.0
COPY --from=dart-runtime /lib/x86_64-linux-gnu/libdl.so.2 /lib/x86_64-linux-gnu/libdl.so.2
COPY --from=dart-runtime /lib/x86_64-linux-gnu/librt.so.1 /lib/x86_64-linux-gnu/librt.so.1

COPY ./example/* /etc/ddns_do/

# Copy generated library
COPY --from=dart-runtime /app/bin/ddns_do_linux /app/bin/ddns_do_linux

ENTRYPOINT ["/app/bin/ddns_do_linux", "-c", "/etc/ddns_do/config.yaml"]

EXPOSE 80
