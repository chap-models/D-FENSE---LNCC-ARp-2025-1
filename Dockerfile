FROM gnuoctave/octave:9.2.0

# No additional Octave packages needed — all dependencies (buffer, armcov)
# are implemented locally to avoid the heavy control/signal/statistics chain.
RUN echo "LNCC-ARp-2025-1" > /etc/model_id
