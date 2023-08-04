interface UrlCheckResult {
  url: string
  status: number
  error: string
}

export async function checkUrls(urls: string[]): Promise<UrlCheckResult[]> {
  const checkResults = []
  for (const url of urls) {
    checkResults.push(await checkUrl(url))
  }
  return checkResults
}

async function checkUrl(url: string): Promise<UrlCheckResult> {
  const result: UrlCheckResult = {
    url,
    status: 0,
    error: ''
  }
  try {
    const response = await fetch(url)
    result.status = response.status
  } catch (error) {
    if (error instanceof Error) {
      result.error = error.message
    } else {
      result.error = 'Unknown error'
    }
  }
  return result
}
