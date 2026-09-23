{{#with_env_prod}}import 'package:{{project_name}}/main.dart' as entry;
void main() => entry.mainCommon();
{{/with_env_prod}}{{^with_env_prod}}// env prod disabled
{{/with_env_prod}}
