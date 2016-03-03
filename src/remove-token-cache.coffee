http   = require 'http'
DeviceManager = require 'meshblu-core-manager-device'

class RemoveDeviceCache
  constructor: (options={}) ->
    {cache,uuidAliasResolver} = options
    @deviceManager = new DeviceManager {uuidAliasResolver, cache}

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {toUuid} = request.metadata
    return @_doCallback request, 404, callback unless toUuid?

    @deviceManager.removeDeviceFromCache uuid: toUuid, (error) =>
      return callback error if error?
      @_doCallback request, 204, callback

module.exports = RemoveDeviceCache
