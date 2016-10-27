var mongodb = require('mongodb').MongoClient;

var books = [
{
    title: 'DevOps Toolkit 2.0',
    genre: 'DevOps',
    author: 'Viktor Farcic',
    link: 'https://www.amazon.com/DevOps-2-0-Toolkit-Containerized-Microservices/dp/B01FEK2HFQ/ref=sr_1_2?s=books&ie=UTF8&qid=1474789952&sr=1-2&keywords=DevOps+Toolkit+2.0',
    image: 'DevOpsToolkit.jpg',
    info: 'This book envelops the whole microservices development and deployment lifecycle using some of the latest and greatest practices and tools. We use Docker, Kubernetes, Ansible, Ubuntu, Docker Swarm and Docker Compose, Consul, etcd, Registrator, confd, and so on. We go through many practices and, even more, tools.'
    },
{
    title: 'The Phoenix Project',
    genre: 'DevOps',
    author: 'Kevin Behr, George Spafford, Gene Kim',
    link: 'https://www.amazon.com/Phoenix-Project-DevOps-Helping-Business/dp/0988262509/ref=sr_1_1?s=books&ie=UTF8&qid=1474790047&sr=1-1&keywords=The+Phoenix+Project',
    image: 'phoenixProject.png',
    info: 'Learn how to recognize problems that happen in IT organizations; how these problems jeopardize nearly every commitment the business makes in Development, IT Operations and Information Security; and how DevOps techniques can fix the problem to help the business win.'
    },
{
    title: 'Site Reliability Engineering',
    genre: 'SRE',
    author: 'Betsy Beyer, Chris Jones, Jennifer Petoff, Niall Richard Murphy',
    link: 'https://www.amazon.com/Site-Reliability-Engineering-Production-Systems/dp/149192912X/ref=sr_1_1?s=books&ie=UTF8&qid=1474790080&sr=1-1&keywords=Site+Reliability+Engineering',
    image: 'googleSRE.png',
    info: 'The overwhelming majority of a software system’s lifespan is spent in use, not in design or implementation. So, why does conventional wisdom insist that software engineers focus primarily on the design and development of large-scale computing systems?'
    },
{
    title: 'The Practice of Cloud System Administration',
    genre: 'Science Fiction',
    author: 'Strata R. Chalup, Christine Hogan, Thomas A. Limoncelli',
    link: 'https://www.amazon.com/Practice-Cloud-System-Administration-Distributed/dp/032194318X/ref=sr_1_1?s=books&ie=UTF8&qid=1474790098&sr=1-1&keywords=The+Practice+of+Cloud+System+Administration',
    image: 'CloudSys.jpg',
    info: 'The Practice of Cloud System Administration, focuses on “distributed” or “cloud” computing and brings a DevOps/SRE sensibility to the practice of system administration. Unsatisfied with books that cover either design or operations in isolation, the authors created this authoritative reference centered around a comprehensive approach'
    }
];

var url =
    'mongodb://db:27017/libraryApp'; //docker mongo

    mongodb.connect(url, function(err, db){
        var collection = db.collection('books');
        collection.insertMany(books, function (err, results) {
            console.log(results);
            db.close();
        });
    });
