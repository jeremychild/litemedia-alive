# Project installation #

_...coming soon..._

# Manual / Server installation #

You might want to do a manual installation on a server. Then you follow these instructions.

  1. Download latest binary and copy it to your bin folder.
  1. Open up your web.config and add the following to handlers section.
> > For IIS 6.0 and below
```
<configuration>
  <system.web>
    <httpHandlers>
      <add path="Alive.axd" verb="*" type="LiteMedia.Alive.Handler, Alive"/>
    </httpHandlers>
  </system.web>
</configuration>
```
> > For IIS 7.0 and above
```
<configuration>
  <system.web>
    <system.webServer>
      <handlers>
        <add name="Alive" path="Alive.axd" verb="*" type="LiteMedia.Alive.Handler, Alive"/>
      </handlers>
    </system.webServer>
  </system.web>
</configuration>
```

Point your browser to the http://webroot/Alive.axd/