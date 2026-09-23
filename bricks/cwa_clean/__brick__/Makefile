build_runner:
	@echo "Building runner..."
	@dart run build_runner build --delete-conflicting-outputs

l10n:
{{#with_i18n}}	@dart run slang{{/with_i18n}}{{^with_i18n}}	@echo "i18n=none, skipping slang"{{/with_i18n}}

gen:
	@make l10n && make build_runner

feature:
ifndef name
	$(error name is required. Usage: make feature name=my_feature)
endif
	@echo "Scaffolding feature $(name) (Fybego feature-first)..."
	@mkdir -p lib/src/features/$(name)/{data,domain,application,presentation}
	@mkdir -p lib/src/features/$(name)/data
	@mkdir -p lib/src/features/$(name)/domain
	@mkdir -p lib/src/features/$(name)/application
	@mkdir -p lib/src/features/$(name)/presentation
	@echo "✓ lib/src/features/$(name)/{data,domain,application,presentation}"

build_android_dev:
	@flutter build apk --release --dart-define-from-file assets/config/dev.json --flavor dev

clean:
	@flutter clean && dart run build_runner clean
