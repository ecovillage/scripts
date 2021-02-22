# Scripts

A couple of bad ideas turning into good ones if used right.

Everything GPLv3 if not mentioned otherwise in fileheader.
Copyright Felix Wolfsteller (with exception of 7linden-apache-rewrite-rules:
Holger Nassenstein), however general consensus is that copyright transfer to
Freundeskreis Ökodorf e.V. can be arranged in peace.

## convert_images.sh

Convert all images in current directory to a jpeg with quality parameter of
85, max width or height 1024px.  Do some minor filename sanitization on the
way.

## csvize_trello_json.sh

Read some json from trello export and make a csv file out of it.

## wordpress_mysql_dump.sh

mysqldump a wordpress database, with connection parameters read from wp_config.php .

## wordpress_create_stage.sh

Create a playground copy of a wordpress instance.  Would be WIP if work on it would continue ...

## 7linden-apache-rewrite-rules

Create a .htacces for apache with mod_rewrite to redirect from specific legacy to new homepage pages.

## update_deb_repo

Maintenance for in-house debian repositories.

## piwik_consume_logfile_idsite1_siebenlinden.sh

Import a apache access.log-style file into piwik.

## import_siebenlinden.org_matomo.sh

Import a apache access.log-style file into matomo (better).

## set_apt_proxy.sh

Set or unset Sieben Linden specific apt-cacher-ng settings, needs zenity.

## view_all_crons.sh

View cron jobs of all users.
