import {findUrlsInFiles} from '../src/findUrls'
import * as process from 'process'
import * as cp from 'child_process'
import * as path from 'path'
import {expect, test} from '@jest/globals'

test('find urls in directory', async () => {
  const input = parseInt('foo', 10)
  const directory = './__tests__/test_dir'
  const urlRegex =
    /http[s]?:\/\/(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+/g
  await expect(findUrlsInFiles(directory, urlRegex, '*.js')).resolves.toEqual([
    'https://mashu.comasdfasdfhttps://dscsdc.com',
    'https://asdf.com',
    'http://diff.com'
  ])
})

// test('wait 500 ms', async () => {
//   const start = new Date()
//   await wait(500)
//   const end = new Date()
//   var delta = Math.abs(end.getTime() - start.getTime())
//   expect(delta).toBeGreaterThan(450)
// })
//
// // shows how the runner will run a javascript action with env / stdout protocol
// test('test runs', () => {
//   process.env['INPUT_MILLISECONDS'] = '500'
//   const np = process.execPath
//   const ip = path.join(__dirname, '..', 'lib', 'main.js')
//   const options: cp.ExecFileSyncOptions = {
//     env: process.env
//   }
//   console.log(cp.execFileSync(np, [ip], options).toString())
// })
