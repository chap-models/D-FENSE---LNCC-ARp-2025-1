FROM gnuoctave/octave:9.2.0@sha256:100d394c57b86469748d26ddafcf73a1074338a66dabcababe2e4e05146772b9

# No additional Octave packages needed — all dependencies (buffer, armcov)
# are implemented locally to avoid the heavy control/signal/statistics chain.
RUN echo "LNCC-ARp-2025-1" > /etc/model_id
