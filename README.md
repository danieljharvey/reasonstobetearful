# reasonstobetearful
Objective-C iOS app for Olympians album 'Reasons to be Tearful'

Pulls a bunch of slogans and sounds from a server and displays/caches/layers them. The finished app is now available on the app store, thought I would make the code public here as it might be useful to somebody. It makes use of the following:

<ul>
  <li>Async JSON requests from a server</li>
  <li>Audio playback from multiple sources</li>
  <li>Visualisation layers based on audio output</li>
  <li>Caching of audio files (to save on data usage)</li>
  <li>Requests push notification and sends token to server</li>
</ul>

Please get in touch with any comments/thoughts/suggestions. My background is in web development, and this was my first native IOS project, so there are definitely things I could be doing better. Pretty sure the separate layers of graphics should all be in one UIView rather than multiple layers to save on resources, for instance.
