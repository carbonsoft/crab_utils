Скрипты для gitlab.

Chained hooks support 
Introduced in GitLab Shell 4.1.0 and GitLab 8.15.

Hooks can be also placed in hooks/<hook_name>.d (global) or custom_hooks/<hook_name>.d (per project) directories supporting chained execution of the hooks.

To look in a different directory for the global custom hooks (those in hooks/<hook_name.d>), set custom_hooks_dir in gitlab-shell config. For Omnibus installations, this can be set in gitlab.rb; and in source installations, this can be set in gitlab-shell/config.yml.

The hooks are searched and executed in this order:

<project>.git/hooks/ - symlink to gitlab-shell/hooks global dir
<project>.git/hooks/<hook_name> - executed by git itself, this is gitlab-shell/hooks/<hook_name>
<project>.git/custom_hooks/<hook_name> - per project hook (this is already existing behavior)
<project>.git/custom_hooks/<hook_name>.d/* - per project hooks
<project>.git/hooks/<hook_name>.d/* OR <custom_hooks_dir>/<hook_name.d>/* - global hooks: all executable files (minus editor backup files)
Files in .d directories need to be executable and not match the backup file pattern (*~).

The hooks of the same type are executed in order and execution stops on the first script exiting with a non-zero value.
