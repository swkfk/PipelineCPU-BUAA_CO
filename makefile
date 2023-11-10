OUT := PipelineMipsCPU.zip
SRC := $(wildcard *)

${OUT}: ${SRC}
	zip -r -0 ${OUT} ${SRC}
	mv ${OUT} ../${OUT}
