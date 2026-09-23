{{#with_env_local}}import 'package:{{project_name}}/main.dart' as entry;
void main() => entry.mainCommon();
{{/with_env_local}}{{^with_env_local}}// env local disabled
{{/with_env_local}}
