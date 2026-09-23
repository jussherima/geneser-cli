{{#with_env_dev}}import 'package:{{project_name}}/main.dart' as entry;
void main() => entry.mainCommon();
{{/with_env_dev}}{{^with_env_dev}}// env dev disabled
{{/with_env_dev}}
