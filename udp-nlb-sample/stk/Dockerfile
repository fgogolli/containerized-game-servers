FROM public.ecr.aws/p9d8y1e7/supertuxkart:arm9

RUN apt-get update -y --fix-missing && \
    apt install -y telnet && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    pip install --no-cache-dir pyenet

COPY server_config.xml start-server.sh /stk-code/
COPY udp-health-probe.py /udp-health-probe.py
