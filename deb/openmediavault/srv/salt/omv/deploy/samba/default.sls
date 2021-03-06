# This file is part of OpenMediaVault.
#
# @license   http://www.gnu.org/licenses/gpl.html GPL Version 3
# @author    Volker Theile <volker.theile@openmediavault.org>
# @copyright Copyright (c) 2009-2018 Volker Theile
#
# OpenMediaVault is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# OpenMediaVault is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenMediaVault. If not, see <http://www.gnu.org/licenses/>.

# Documentation/Howto:
# http://wiki.samba.org/index.php/1.0._Configuring_Samba
# http://www.tim-bormann.de/anleitung-installation-samba-server-als-dateiserver-unter-debian-linux

{% set config = salt['omv_conf.get']('conf.service.smb') %}
{% set dirpath = '/srv/salt' | path_join(slspath) %}

include:
{% for file in salt['file.readdir'](dirpath) | sort %}
{% if file | regex_match('^(\d+.+).sls$', ignorecase=True) %}
  - .{{ file | replace('.sls', '') }}
{% endif %}
{% endfor %}

{% if config.enable | to_bool %}

test_samba_service_config:
  cmd.run:
    - name: "samba-tool testparm --suppress-prompt"

start_samba_service:
  service.running:
    - name: smbd
    - enable: True
    - require:
      - cmd: test_samba_service_config
    - watch_in:
      - service: start_samba_service_nmbd

start_samba_service_nmbd:
  service.running:
    - name: nmbd
    - enable: True

{% else %}

start_samba_service:
  test.nop

stop_samba_service_smbd:
  service.dead:
    - name: smbd
    - enable: False

stop_samba_service_nmbd:
  service.dead:
    - name: nmbd
    - enable: False

{% endif %}
