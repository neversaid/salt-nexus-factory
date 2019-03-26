{{ saltenv }}:
  'roles:nexus':
    - match: grain
    - nexus.configuration
