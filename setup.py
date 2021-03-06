from setuptools import find_packages, setup

setup(name='yesbina',
      packages=find_packages(),
      install_requires=['dnspython',
                        'python-dateutil',
                        'flask',
                        'flask-jsonify-emidln',
                        'beautifulsoup4',
                        'hy',
                        'grequests',
                        'requests',
                        'sleekxmpp',
                        'python-Levenshtein'],
      entry_points={
          'console_scripts': [
              'yesbina-xmpp-bot = yesbina.xmpp_cli:main']
          })
