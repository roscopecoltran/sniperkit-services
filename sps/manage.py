import sys
from app import main

if __name__ == '__main__':
    if len(sys.argv) == 2 and sys.argv[1] == 'admin_config':
        from utils.admin import generate_ng_admin_config
        print('Generate admin config')
        generate_ng_admin_config()
        print('Configuration successfully created, exiting ')
    else:
        main()