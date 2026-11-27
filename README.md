# Gemeente Zuiddrecht

Een demo-omgeving van de gemeente Zuiddrecht. Die gemeente bestaat niet. U start een eigen Nextcloud-werkplek in de huisstijl van Zuiddrecht, met medewerkers, groepen en startpagina's al ingevuld. Zo probeert u zelf hoe een gemeentelijke werkplek op Nextcloud werkt.

De omgeving bevat:

- **Nextcloud 34**, de werkplek zelf.
- **[Thematiq](https://github.com/ConductionNL/thematiq)**, met het thema Zuiddrecht: kleuren, lettertype, logo en de driekleurige streep.
- **[Launchpad](https://github.com/ConductionNL/launchpad)**, de startpagina. Elke medewerker landt op een eigen dashboard.

## Starten

U heeft [Docker](https://docs.docker.com/get-docker/) met Docker Compose nodig.

```bash
git clone https://github.com/ConductionNL/zuiddrecht.git
cd zuiddrecht
docker compose up -d
```

De eerste start duurt een paar minuten. Nextcloud installeert zichzelf, zet het thema aan en laadt de demo. Daarna opent u <http://localhost:8080>.

`docker compose ps` toont `healthy` bij de werkplek zodra alles klaar is.

## Inloggen

Alle demo-medewerkers hebben het wachtwoord `Zuiddrecht-demo-2026!`.

| Gebruiker | Wie | Wat u ziet |
|---|---|---|
| `pieter` | Pieter Jansen, vergunningen | Vandaag, Mijn werkplek, Intranet, Team Vergunningen, Managementinformatie |
| `marieke` | Marieke Jansen, teamleider vergunningen | Beheert het dashboard van Team Vergunningen |
| `sanne` | Sanne de Vries, vergunningen | Team Vergunningen, mag widgets toevoegen |
| `hanneke` | Hanneke Visser, directie | Managementinformatie |
| `communicatie` | Team Communicatie | Beheert het Intranet Zuiddrecht |
| `beheer` | Functioneel beheerder | De beheerpagina's |
| `nieuw` | Noor Nieuw, net in dienst | Het eerste bezoek, nog zonder dashboard |

De beheerder is `admin` met wachtwoord `admin`. De volledige lijst staat in de [documentatie van Launchpad](https://github.com/ConductionNL/launchpad/blob/development/docs/features/demo-seed.md).

Gebruik deze omgeving alleen als demo. De wachtwoorden zijn openbaar.

## Instellen

Kopieer `.env.example` naar `.env` en pas aan wat u wilt. Zonder `.env` gelden de standaardwaarden.

| Instelling | Standaard | Betekenis |
|---|---|---|
| `PORT` | `8080` | Poort op uw computer |
| `ADMIN_PASSWORD` | `admin` | Wachtwoord van de beheerder |
| `DEMO_PASSWORD` | leeg | Ander wachtwoord voor de demo-medewerkers |
| `DEMO_LANGUAGE` | `nl` | Taal van de dashboards: `nl` of `en` |
| `ZUIDDRECHT_TAG` | `latest` | Versie van de image |

Deze instellingen werken bij de eerste start. Wijzigt u ze later, begin dan opnieuw.

## Opnieuw beginnen

```bash
docker compose down -v
docker compose up -d
```

`down -v` wist alle gegevens. De volgende start zet de demo weer schoon neer.

## Op een server zetten

Zet de werkplek achter een reverse proxy met HTTPS en vul in `.env` uw domein in:

```bash
TRUSTED_DOMAINS=localhost zuiddrecht.example.nl
OVERWRITE_PROTOCOL=https
OVERWRITE_CLI_URL=https://zuiddrecht.example.nl
```

Kies dan ook een eigen `ADMIN_PASSWORD`, `DEMO_PASSWORD` en `DB_PASSWORD`.

## Hoe het werkt

De image `ghcr.io/conductionnl/zuiddrecht` is de officiële Nextcloud-image met Thematiq en Launchpad erin. Er wordt bij het starten dus niets gedownload. Bij de eerste start draait [`hooks/post-installation/10-zuiddrecht.sh`](hooks/post-installation/10-zuiddrecht.sh). Dat script zet de apps aan, kiest het thema en laadt de demo.

De versies van de apps staan in de [`Dockerfile`](Dockerfile). Een wijziging op `main` bouwt en publiceert een nieuwe image. Wilt u zelf bouwen, gebruik dan `docker compose up -d --build`.

Widgets die gegevens uit andere apps tonen, zoals zaken, blijven leeg. Die apps zitten niet in deze demo. Het weerbericht heeft internettoegang nodig.

## Licentie

[EUPL-1.2](LICENSE). Gemaakt door [Conduction](https://conduction.nl).
