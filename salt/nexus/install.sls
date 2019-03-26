
{%- from "nexus/map.jinja" import nexus with context %}
{% set nexus_src_path = nexus.pkg_install.savepath ~ "/" ~ nexus.pkg_install.version  %}
{% set nexus_src_path_app = nexus_src_path ~ "/nexus-" ~ nexus.pkg_install.version %}
{% set nexus_src_path_data = nexus_src_path ~ "/sonatype-work" %}


nexus_install_group:
  group.present:
    - name: {{ nexus.group.name }}
    - system: True 
    {% if nexus.group.gid %}
    - gid: {{ nexus.group.gid }}
    {% endif %}
    - system: True
 
nexus_install_user:
  user.present:
    - name: {{ nexus.user.name }}
    - home: {{ nexus.user.home }}
    - createhome: True
    - system: True
    - shell: /sbin/nologin 
    - groups:
      - {{ nexus.group.name }}
    {% if nexus.user.uid %}
    - uid: {{ nexus.user.uid }}
    {% endif %}
    - require:
      - group: nexus_install_group

nexus_install_create_download_folder:
  file.directory:
    - name: {{ nexus.pkg_install.savepath }}
    - dir_mode: 755
    - file_mode: 644
    - user: {{ nexus.user.name }}
    - group: {{ nexus.group.name }}
    - recurse:
      - user
      - group
    - require:
      - user: nexus_install_user

nexus_install_create_version_folder:
  file.directory:
    - name: {{ nexus.pkg_install.savepath }}/{{ nexus.pkg_install.version }}
    - dir_mode: 755
    - file_mode: 644
    - user: {{ nexus.user.name }}
    - group: {{ nexus.group.name }}
    - recurse:
      - user
      - group
    - require:
      - file: nexus_install_create_download_folder

nexus_install_extract_archive:
  archive.extracted:
    - name: {{  nexus_src_path }}
    - source: {{ nexus.pkg_install.srcpath }}
    - archive_format: tar
    - if_missing: {{ nexus.pkg_install.savepath }}/nexus-{{ nexus.pkg_install.version}}.txt
    - require:
      - file: nexus_install_create_version_folder

nexus_install_nexus_app:
   cmd.run:
    - name: 'cp -R {{ nexus_src_path_app  }} {{ nexus.install.path }}/nexus-{{ nexus.pkg_install.version }}'
    - require: 
      - archive: nexus_install_extract_archive 
    - unless: 'test -f {{ nexus.install.path }}/nexus-{{ nexus.pkg_install.version }}/bin/nexus'


