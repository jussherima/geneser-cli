{{#with_env_stg}}import 'package:{{project_name}}/main.dart' as entry;
void main() => entry.mainCommon();
{{/with_env_stg}}{{^with_env_stg}}// env stg disabled
{{/with_env_stg}}
