#!/usr/bin/python

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_own_module
short_description: Custom module my_own_module
version_added: "1.0.0"
description: Custom module my_own_module
options:
    path:
        description: Path to file
        required: true
        type: str
    content:
        description: Content of the file
        required: false
        type: str
extends_documentation_fragment:
    - my_own_namespace.yandex_cloud_elk.my_doc_fragment_name
author:
    - Yuri Artemiev
'''

EXAMPLES = r'''
# Save content to file
- name: Create file
  my_own_namespace.yandex_cloud_elk.my_own_module:
    path: "{{ path }}"
    content: "{{ content }}"
'''

RETURN = r'''
changed:
    description: If file changed
    type: bool
    returned: always
    sample: True
'''

from ansible.module_utils.basic import AnsibleModule
import os

def run_module():
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=False, default="Default content message")
    )
    result = dict(
        changed=False
    )
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    if module.check_mode:
        module.exit_json(**result)

    if not(os.path.exists(module.params['path']) 
    and os.path.isfile(module.params['path'])
    and open(module.params['path'],'r').read() == module.params['content']):
        try:
            with open(module.params['path'], 'w') as file:
                file.write(module.params['content'])
                result['changed'] = True
        except Exception as e:
            module.fail_json(msg=f"Something gone wrong: {e}", **result)

    if module.params['path'] == 'fail me':
        module.fail_json(msg='You requested this to fail', **result)

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
