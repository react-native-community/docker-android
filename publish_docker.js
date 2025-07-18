const execSync = require("child_process").execSync;

function publishDocker() {
  const now = new Date()
  const repo = `vasylnahuliak/react-native-android`
  const cmd =`
docker login -u ${process.env.DOCKER_USER} -p ${process.env.DOCKER_PASS}
docker build -t ${repo} .
docker push ${repo}
  `
  cmd.trim().split("\n").map(i => {
    const cmd = i.trim();
    if (cmd) {
      if (!cmd.includes('login')) {
        console.log(cmd);
      }
      const output = execSync(cmd)
      console.log(output.toString());
    }
  })
}

publishDocker()
