import * as fs from 'fs'
import * as path from 'path'
import {glob} from 'glob'
import * as core from '@actions/core'
export async function findUrlsInFiles(
  // directory: string,
  urlRegex: RegExp,
  filesGlob: string
): Promise<string[]> {
  const urlsInFiles = []
  // print cwd
  core.info(`Current working directory: ${process.cwd()}`)
  // Find python files
  const fullPath = path.join(directory, filesGlob)
  const files = await glob(fullPath, {ignore: 'node_modules/**'})
  for (const file of files) {
    // Read file content
    core.info(`Reading file: ${file}`)
    const content = await fs.promises.readFile(file, 'utf-8')
    // Find URLs using regex
    const matchedUrlsIterator = content.matchAll(urlRegex)
    // Print file name and found URLs
    if (matchedUrlsIterator) {
      core.info(`Found URLs in ${file}:`)
      for (const urls of matchedUrlsIterator) {
        for (const url of urls) {
          core.info(url)
          urlsInFiles.push(url)
        }
      }
    }
  }
  return urlsInFiles
}
