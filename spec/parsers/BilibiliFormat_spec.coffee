'use strict'
describe 'BilibiliFormat', ->
  jasmine.getFixtures().fixturesPath = "test/"

  it 'provides xml parser', ->
    expect(typeof BilibiliFormat.XMLParser).toBe 'function'

  it 'provides text parser', ->
    expect(typeof BilibiliFormat.TextParser).toBe 'function'

  describe '.XMLParser', ->
    parser = null
    document = null

    beforeAll ->
      xmltext = readFixtures 'av207527.xml'
      document = (new DOMParser()).parseFromString xmltext, "application/xml"
    beforeEach ->
      parser = new BilibiliFormat.XMLParser()

    it 'has sane defaults', ->
      expect(parser._attemptFix).toBe true
      expect(parser._logBadComments).toBe true

    it 'can be configured', ->
      parser = new BilibiliFormat.XMLParser 
        attemptFix: false
        logBadComments: false
      expect(parser._attemptFix).toBe false
      expect(parser._logBadComments).toBe false

    it 'only accepts xml documents', ->
      expect(parser.parseOne "foo").toBe null
      expect(parser.parseMany "foo").toBe null

    it 'can parse one', ->
      expect(parser.parseOne document.getElementsByTagName('d')[0]).toEqual
        stime:    15105
        size:     25
        color:    16777215
        mode:     1
        date:     1388314569
        pool:     0
        position: 'absolute'
        dbid:     364586099
        hash:     '1a87dd40'
        border:   false
        text:     '关了弹幕瞬间好多了'

    it 'can parse many', ->
      comments = parser.parseMany document
      expect(comments.length).toBe 12546
      expect(comments[0]).toEqual
        stime:    15105
        size:     25
        color:    16777215
        mode:     1
        date:     1388314569
        pool:     0
        position: 'absolute'
        dbid:     364586099
        hash:     '1a87dd40'
        border:   false
        text:     '关了弹幕瞬间好多了'

    it 'can parse scripting', ->
      xmltext = readFixtures 'scripting/tsubasa.xml'
      comments = parser.parseMany (new DOMParser()).parseFromString xmltext, 'application/xml'
      expect(comments.length).toBe 654
      expect(comments[0].mode).toEqual 7
      expect(comments[653].mode).toEqual 8

    it 'can parse advanced', ->
      xmltext = readFixtures 'boss.xml'
      comments = parser.parseMany (new DOMParser()).parseFromString xmltext, 'application/xml'
      expect(comments.length).toBe 1000
      expect(comments[0].mode).toEqual 7
      expect(comments[0].motion).not.toBe null

  describe '.TextParser', ->
    parser = null
    xmltext = null

    beforeAll ->
      xmltext = readFixtures 'av207527.xml'
    beforeEach ->
      parser = new BilibiliFormat.TextParser()

    it 'has sane defaults', ->
      expect(parser._allowInsecureDomParsing).toBe true
      expect(parser._attemptEscaping).toBe true

    it 'can be configured', ->
      parser = new BilibiliFormat.TextParser
        allowInsecureDomParsing: false
        attemptEscaping: false
      expect(parser._allowInsecureDomParsing).toBe false
      expect(parser._attemptEscaping).toBe false

    it 'propagates parameters', ->
      parser = new BilibiliFormat.TextParser
        attemptFix: false
        logBadComments: false
        allowInsecureDomParsing: true
      expect(parser._xmlParser instanceof BilibiliFormat.XMLParser).toBe true
      expect(parser._xmlParser._attemptFix).toBe false
      expect(parser._xmlParser._logBadComments).toBe false

    it 'can parse many (insecure dom parsing)', ->
      comments = parser.parseMany xmltext
      expect(comments.length).toBe 12546
      expect(comments[0]).toEqual
        stime:    15105
        size:     25
        color:    16777215
        mode:     1
        date:     1388314569
        pool:     0
        position: 'absolute'
        dbid:     364586099
        hash:     '1a87dd40'
        border:   false
        text:     '关了弹幕瞬间好多了'

