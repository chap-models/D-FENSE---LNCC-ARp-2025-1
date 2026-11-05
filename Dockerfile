FROM gnuoctave/octave:11.3.0@sha256:b22abbe607c15ed821521ab9cf8a7c466dc47506730a0de9503bd554731b3e32

# No additional Octave packages needed — all dependencies (buffer, armcov)
# are implemented locally to avoid the heavy control/signal/statistics chain.
RUN echo "LNCC-ARp-2025-1" > /etc/model_id
