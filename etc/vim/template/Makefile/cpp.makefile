#.SUFFIXES: .cpp .o

CXX=g++
EXE_EXT=.out
OBJ_EXT=.o
TARGET=a${EXE_EXT}
FILES=main test01
OBJS=${FILES:=${OBJ_EXT}}
FLAGS=-Wall -std=c++11
DEBUG=-g
LIBS=pthread
LIBS_FLAGS=${addsuffix ${LIBS},-l}

DEBUG_TARGET=${TARGET:${EXE_EXT}=${DEBUG}${EXE_EXT}}
DEBUG_OBJS=${OBJS:${OBJ_EXT}=${DEBUG}${OBJ_EXT}}

.PONEY=all clean release debug

all: release debug

release: ${TARGET}

debug: ${DEBUG_TARGET}

${TARGET}: ${OBJS}
	${CXX} ${FLAGS} ${LIBS_FLAGS} -o $@ $^

${DEBUG_TARGET}: ${DEBUG_OBJS}
	${CXX} ${FLAGS} ${DEBUG} ${LIBS_FLAGS} -o $@ $^

clean:
	rm -rf ${TARGET} ${DEBUG_TARGET} ${OBJS} ${DEBUG_OBJS}

%.o: %.cpp
	${CXX} ${FLAGS} -o $@ -c $^

%-g.o: %.cpp
	${CXX} ${FLAGS} ${DEBUG} -o $@ -c $^

