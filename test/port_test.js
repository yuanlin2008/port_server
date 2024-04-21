// https://github.com/matehat/node-erlang-port
// https://github.com/okeuday/erlang_js
var fs = require('fs')
input = fs.createReadStream(null, {fd:3})
output = fs.createWriteStream(null, {fd:4})
input.on("data", data=>{
    output.write(data)
})