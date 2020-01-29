# Thanks Vishal, https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
black() {
  echo -e "\e[30m${1}\e[0m"
}

red() {
  echo -e "\e[31m${1}\e[0m"
}

green() {
  echo -e "\e[32m${1}\e[0m"
}

yellow() {
  echo -e "\e[33m${1}\e[0m"
}

blue() {
  echo -e "\e[34m${1}\e[0m"
}

magenta() {
  echo -e "\e[35m${1}\e[0m"
}

cyan() {
  echo -e "\e[36m${1}\e[0m"
}

gray() {
  echo -e "\e[90m${1}\e[0m"
}

