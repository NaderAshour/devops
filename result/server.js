var express = require('express'),
    async = require('async'),
    { Pool } = require('pg'),
    path = require('path'),
    cookieParser = require('cookie-parser'),
    app = express(),
    server = require('http').Server(app),
    io = require('socket.io')(server, { path: '/result/socket.io' });

var port = process.env.PORT || 4000;

// PostgreSQL configuration from environment variables - NO HARDCODED IPs
var pgHost = process.env.POSTGRES_HOST || 'localhost';
var pgPort = process.env.POSTGRES_PORT || '5432';
var pgUser = process.env.POSTGRES_USER || 'voteapp';
var pgPassword = process.env.POSTGRES_PASSWORD || 'VoteApp123!';
var pgDatabase = process.env.POSTGRES_DB || 'votingdb';

console.log('Result service connecting to PostgreSQL at ' + pgHost + ':' + pgPort);

io.on('connection', function (socket) {

  socket.emit('message', { text : 'Welcome!' });

  socket.on('subscribe', function (data) {
    socket.join(data.channel);
  });
});

var pool = new Pool({
  host: pgHost,
  port: parseInt(pgPort),
  user: pgUser,
  password: pgPassword,
  database: pgDatabase
});

async.retry(
  {times: 1000, interval: 1000},
  function(callback) {
    pool.connect(function(err, client, done) {
      if (err) {
        console.error("Waiting for db");
      }
      callback(err, client);
    });
  },
  function(err, client) {
    if (err) {
      return console.error("Giving up");
    }
    console.log("Connected to db");
    getVotes(client);
  }
);

function getVotes(client) {
  client.query('SELECT vote, COUNT(id) AS count FROM votes GROUP BY vote', [], function(err, result) {
    if (err) {
      console.error("Error performing query: " + err);
    } else {
      var votes = collectVotesFromResult(result);
      io.sockets.emit("scores", JSON.stringify(votes));
    }

    setTimeout(function() {getVotes(client) }, 1000);
  });
}

function collectVotesFromResult(result) {
  var votes = {a: 0, b: 0};

  result.rows.forEach(function (row) {
    votes[row.vote] = parseInt(row.count);
  });

  return votes;
}

app.use(cookieParser());
app.use(express.urlencoded());

// Serve static files from /result path as well
app.use('/result', express.static(__dirname + '/views'));
app.use(express.static(__dirname + '/views'));

// Handle both / and /result paths
app.get('/', function (req, res) {
  res.sendFile(path.resolve(__dirname + '/views/index.html'));
});

app.get('/result', function (req, res) {
  res.sendFile(path.resolve(__dirname + '/views/index.html'));
});

server.listen(port, function () {
  var port = server.address().port;
  console.log('App running on port ' + port);
});
