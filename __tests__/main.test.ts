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
