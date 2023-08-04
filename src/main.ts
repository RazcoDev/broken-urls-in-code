import * as core from '@actions/core'
import {findUrlsInFiles} from './findUrls'
import {checkUrls} from './checkUrls'

async function run(): Promise<void> {
  try {
    const filesGlobe: string = core.getInput('files-globe')
    const directory: string = core.getInput('directory')
    const urlRegex = RegExp(core.getInput('url-regex'), 'gi')
    core.info(
      `Scanning broken URLs in files matching the input regex: "${filesGlobe}" `
    )
    core.info(`Using URL regex: ${urlRegex}`)
    core.info(`In directory: ${directory}`)
    const urlsArray: string[] = await findUrlsInFiles(
      directory || '.',
      urlRegex,
      filesGlobe
    )
    core.info(`Found ${urlsArray.length} URLs`)
    core.debug(`URLs: ${urlsArray.join(', ')}`)
    const checkResults = await checkUrls(urlsArray)
    core.debug(`Check results: ${checkResults.join(', ')}`)
    const brokenUrls = checkResults.filter(
      result => result.status >= 400 || result.error !== ''
    )
    if (brokenUrls.length > 0) {
      core.info(`Broken URLs: ${JSON.stringify(brokenUrls)}`)
      core.setFailed(`Found ${brokenUrls.length} broken URLs`)
    } else {
      core.info('All URLs are working !')
    }
  } catch (error) {
    if (error instanceof Error) core.setFailed(error.message)
  }
}

run()
