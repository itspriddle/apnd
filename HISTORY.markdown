# 0.2.0 - 2011-04-04

Note that v0.2.0 fixes a critical error, and that previous releases of APND
should not be used.

* Fixes a critical error in `APND::Daemon::Protocol` which caused problems
  with notifications containing new line characters in their message. Props to
  [mwotton](https://github.com/mwotton).
* Merged `apnd` and `apnd-push` CLI tools into `apnd`.
* Added support for Apple Push Notification Feedback Service
