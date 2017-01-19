FROM python:2.7

RUN git clone https://github.com/Unifield/ufcheck && \
	pip install --no-cache-dir ufcheck/server
EXPOSE 20 110 8070
CMD cd ufcheck/server && python netrpc_server.py 20 110 8070
