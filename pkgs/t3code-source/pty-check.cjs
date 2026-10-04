const assert = require('node:assert/strict');
const pty = require(`${process.argv[2]}/libexec/t3code/apps/server/node_modules/node-pty`);
const terminal = pty.spawn(process.argv[3], ['-c', 'printf t3-source-pty-ready'], {
  cwd: process.cwd(), env: process.env, cols: 80, rows: 24,
});
let output = '';
const timeout = setTimeout(() => {
  terminal.kill();
  throw new Error('Native terminal startup timed out');
}, 10000);
terminal.onData(data => { output += data; });
terminal.onExit(({ exitCode }) => {
  clearTimeout(timeout);
  assert.equal(exitCode, 0);
  assert.match(output, /t3-source-pty-ready/);
  console.log('Source-built terminal addon works');
});
