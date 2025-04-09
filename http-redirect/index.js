const configContent = process.env.REDIRECT_CONFIG;

if (!configContent) {
  console.error('Error: REDIRECT_CONFIG environment variable is not set');
  process.exit(1);
}

let redirects;
try {
  redirects = JSON.parse(configContent);
} catch (error) {
  console.error('Error parsing JSON from environment variable:', error);
  process.exit(1);
}

const isValidRedirect = (redirect) => {
  return (
    redirect.hostFrom &&
    redirect.hostTo &&
    (redirect.httpCode === 301 || redirect.httpCode === 302 || redirect.httpCode === 307) &&
    (!redirect.scheme || ['http:', 'https:'].includes(redirect.scheme))
  );
};

if (!Array.isArray(redirects) || !redirects.every(isValidRedirect)) {
  console.error('Error: Invalid redirect configuration format');
  process.exit(1);
}

const server = Bun.serve({
  port: process.env.PORT || 3000,
  fetch(req) {
    const url = new URL(req.url);

    if (url.pathname === '/_health') {
      return new Response('OK', { status: 200 });
    }

    const redirect = redirects.find(r => r.hostFrom === url.hostname);
    if (redirect) {
      const redirectUrl = new URL(url);
      redirectUrl.hostname = redirect.hostTo;
      redirectUrl.protocol = redirect.scheme || 'https:';

      if (redirect.pathPrefixTo) {
        const currentPath = redirectUrl.pathname.startsWith('/') ? redirectUrl.pathname : `/${redirectUrl.pathname}`;
        const prefixPath = redirect.pathPrefixTo.endsWith('/') ? redirect.pathPrefixTo.slice(0, -1) : redirect.pathPrefixTo;
        redirectUrl.pathname = `${prefixPath}${currentPath}`;
      }

      console.log(`Redirecting ${url.toString()} to ${redirectUrl.toString()} [${redirect.httpCode}]`);

      return new Response(null, {
        status: redirect.httpCode,
        headers: {
          'Location': redirectUrl.toString()
        }
      });
    }

    console.log(`No redirect found for ${url.toString()} [404]`);
    return new Response('Not Found', { status: 404 });
  },
});

console.log(`Redirect server listening on port ${server.port}`);
