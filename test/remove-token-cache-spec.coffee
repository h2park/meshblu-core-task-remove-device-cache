RemoveDeviceCache = require '..'
crypto = require 'crypto'
redis  = require 'fakeredis'
uuid   = require 'uuid'

describe 'RemoveDeviceCache', ->
  beforeEach ->
    @redisKey = uuid.v1()
    @uuidAliasResolver = resolve: (uuid, callback) => callback null, uuid
    @sut = new RemoveDeviceCache
      cache: redis.createClient(@redisKey)
      uuidAliasResolver: @uuidAliasResolver
    @cache = redis.createClient @redisKey

  describe '->do', ->
    beforeEach (done) ->
      @cache.set 'device-uuid', '', done

    describe 'when the uuid/token combination is in the cache', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'asdf'
            auth:
              uuid:  'barber-slips'
              token: 'Just a little off the top'
            toUuid: 'device-uuid'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 204', ->
        expect(@response).to.deep.equal
          metadata:
            responseId: 'asdf'
            code: 204
            status: 'No Content'

      it 'should remove the token', (done) ->
        @cache.exists 'device-uuid', (error, exists) =>
          return done error if error?
          expect(exists).to.equal 0
          done()
