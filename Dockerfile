FROM gnuoctave/octave:9.4.0@sha256:f8be6269b4783a9828cf2141a4388fd194f8f0be8a8e193c3ec388a6318be973

# No additional Octave packages needed — all dependencies (buffer, armcov)
# are implemented locally to avoid the heavy control/signal/statistics chain.
RUN echo "LNCC-ARp-2025-1" > /etc/model_id
