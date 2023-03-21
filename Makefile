MODEL_SRC := $(wildcard src/model/*.cr)

SEED_TOOL_SRC := $(wildcard src/seed_tool/*.cr)
SEED_TOOL_SRC += $(MODEL_SRC)

SHOWCASE_SRC := $(wildcard src/showcase/*.cr)
SHOWCASE_SRC += $(MODEL_SRC)

all: seed-tool showcase

bin/seed-tool: $(SEED_TOOL_SRC)
	@mkdir -p bin/
	crystal build -o bin/seed-tool --error-trace src/seed_tool/main.cr

seed-tool: bin/seed-tool

bin/showcase: $(SHOWCASE_SRC)
	@mkdir -p bin/
	crystal build -o bin/showcase --error-trace src/app/main.cr

showcase: bin/showcase

spec:
	crystal spec --error-trace spec/

clean:
	rm -f bin/seed-tool
	rm -f bin/showcase

.env:
	cp -p .env.example .env
.env.test:
	sed -e 's/development/test/' .env.example > .env.test

dotenv: .env .env.test

deps: clean
	rm -rf lib/* lib/.shards.info
	shards install --frozen

db-seed: bin/seed-tool
	@echo "Seeding set 1/3..."
	bin/seed-tool --employees 33000 --mentors 11000 --team-id=1
	@echo "Seeding set 2/3..."
	bin/seed-tool --employees 22000 --mentors 11000 --team-id=2
	@echo "Seeding set 3/3..."
	bin/seed-tool --employees 12000 --mentors 21000 --team-id=3


.PHONY: all seed-tool showcase spec clean dotenv deps db-seed
