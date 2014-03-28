from setuptools import find_packages, setup

setup(name='yesbina',
      packages=find_packages(),
      install_requires=['python-dateutil',
                        'flask',
                        'flask-jsonify-emidln',
                        'beautifulsoup4',
                        'hy',
                        'requests'])
