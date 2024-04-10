# up.sh
up.sh to automatically create __Dockerfile__ and __compose.yml__ 
for your projects.

It is useful especially if you are working on different projects different frameworks frequently.  
Or if you want to get a glimpse on how to containerize your local app development.

3 minutes of reading the README and examining the example usage, you are good to go with __up.sh__

## Requirements
To run scripts properly all you need is:  
\- Bash or Bash compatible shell  
\- Python3  

Will run in almost any modern Linux distribution with no additional installation.  
Should run in WSL and probably would run in Git Bash too (not tested yet)

*And surely you need Docker or one of its alternatives installed (Podman, Nerdctl etc.).  
_Latest versions to not run into compose file version related problems._

## Installation
Just clone the repository and start examining __up.sh__ and __types__ directory  

There are:  
- Types  
- Apps  

Types are reusable scripts that do the magical part of creating __Dockerfile__ and __compose.yml__ files for your Apps.
You can find them under types directory, edit them or create your own types when needed.

You need to define your Apps in __apps.json__ file. This all you need to do to start using __up.sh__

## Example Usage
#### 1- Make your app directory ready
Let's create an example flask app:

```bash
mkdir ~/upsh-demo-app
```

```bash
# For this example we will use 'python3-flask' type
cat << EOF > ~/upsh-demo-app/app.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

if __name__ == '__main__':
    app.run(debug=True) 
EOF
```

```bash
# and a requirements.txt 
cat << EOF > ~/upsh-demo-app/requirements.txt
flask
EOF
```

#### 2- Config your app in the apps.json file

you may use apps.json.example as a template
```bash
cp apps.json.example apps.json
```

```json:apps.json
{
    "apps": [
        {
            "dir": "~/upsh-demo-app",
            "name": "my-app",
            "type": "python3-flask",
            "port": 5000
        }
    ]
}
```

<br />

#### 3- Run the script
```bash
./up.sh my-app
```
And it will create Dockerfile and compose.yml inside /apps/my-app  

..| apps/  
.........| my-app/  
................ __compose.yml__  
................ __Dockerfile__  


__up.sh__ will run `docker compose up -d` right after creating the Docker files.  


![flask app](https://aliefee.page/assets/upshhello.jpg)  

<br />

## Purpose of up.sh
There is already mature toolings out there to simplify 'containerization' of local development with nice UIs and wrappings. I wanted to compose a tooling that lives in shell and gives a glimpse of how 
to Dockerize (or containerize) your local development. You will likely have the glimpse of bash 
scripting and running containers after giving __up.sh__ a few tries.  

What up.sh does essentially is simply:  
- creating Dockerfile and compose.yml for your __app__ according to its __type__
- running `docker compose up -d`

### if you only want to create __Dockerfile__ and __compose.yml__ files 
but don't want __up.sh__ to run `docker compose up -d` you can comment out 
`up_loop` command in __up.sh__ file
```bash:up.sh
#up_loop
```
After creating __Dockerfile__ and __compose.yml__ files, you can just take your app 
folder to somewhere else and fly away from __up.sh__ project. This is another fair use of __up.sh__. 🙃  

### you can run the script with your favourite container engine that supports Docker Compose.  
just change the value of `CONTAINER_CLI` in up.sh
```bash:up.sh
CONTAINER_CLI="docker compose"
```
or
```bash:up.sh
CONTAINER_CLI="podman-compose"
```
or
```bash:up.sh
CONTAINER_CLI="nerdctl compose"
```

<br />

!!! Using the scripts in this project for production deployment or testing would be extremely dangerous! Use only in your local machine.

## Contribution
This project is not intended to transform into another cli wrapper or a project with many configuration and a UI
or whatsoever in the future.  

I will try to keep scripts and the structure as intuitive and simple as possible
in this repository.

- new "type"s
- bug reports (especially related with working with different terminals)
- recommendations for better naming or even for new structure
- best practices
- any kind of feedback

are gratefully welcomed.

#### indefinite roadmap:
- [ ] get rid of python and json files. make everything pure shell script
- [ ] make sh-compatible
- [ ] tests

 +Personally I am a fan of podman's daemonless runtime and currently interested in 
 switching from compose to **_podman kube play_** for my local dev env. In the future, I may add that 
 functionality to up.sh or create a seperate script for that purpose.

[Telegram group](https://t.me/updotsh)

## License
Mozilla Publich License 2.0
