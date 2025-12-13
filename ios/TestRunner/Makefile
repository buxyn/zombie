CC = clang
FRAMEWORKS = -framework Foundation

SOURCE_FILES = MainTest.m ../GeohashHelper.m
OUT = run_tests

all: clean build run

build:
	$(CC) $(FRAMEWORKS) $(SOURCE_FILES) -o $(OUT)

run:
	@echo "--- Running ---"
	@./$(OUT)

clean:
	rm -f $(OUT)
