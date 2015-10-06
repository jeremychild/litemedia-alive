# First configuration #
No configuration is probably your first configuration. When you don't supply any configuration with Alive, default configuration will kick in.

# Create configuration #
Add configuration section to web.config.

```
<configuration>
  <configSections>
    <sectionGroup name="Alive" type="LiteMedia.Alive.Configuration, Alive">
      <section name="counters" type="LiteMedia.Alive.CountersSection, Alive"/>
    </sectionGroup>
  </configSections>
  
  <Alive>
    <counters>
    ... add counters here ...
    </counters>
  </Alive>
</configuration>
```

Inside the counter element you put your charts, here called group. Inside a group you choose what counters should be visible on that chart.

```
<groups>
  <group name="Hardware" updateLatency="1000">
    <counter 
      name="CPU" 
      categoryName="Processor Information"
      counterName = "% Processor Time"
      instanceName = "_Total" />
  </group>
</groups>
```

| **xml element** | **description** |
|:----------------|:----------------|
| group@name      | Chart top title |
| group@updateLatency | How often it should be updated in ms |
| counter@name    | Name of the chart line |
| counter@categoryName | What category in the system the counter is found |
| counter@counterName | Name of the performance counter in the system |
| instanceName    | A specific instance of the counter (optional) |

This will give you one chart that displays total CPU usage.

![https://litemedia.blob.core.windows.net/media/Default/BlogPost/blog/cpu_total.png](https://litemedia.blob.core.windows.net/media/Default/BlogPost/blog/cpu_total.png)

If you want to track individual cores, you can add more counters to the same chart. The configuration for this would look like following.

```
<group name="Hardware" updateLatency="1000">
  <counter 
    name="CPU" 
    categoryName="Processor Information"
    counterName = "% Processor Time"
    instanceName = "_Total" />
  <counter
    name="CPU#1"
    categoryName="Processor Information"
    counterName = "% Processor Time"
    instanceName = "0,0" />
  <counter
    name="CPU#2"
    categoryName="Processor Information"
    counterName = "% Processor Time"
    instanceName = "0,1" />
  </group>
</groups>
```

![https://litemedia.blob.core.windows.net/media/Default/BlogPost/blog/cpu_individual.png](https://litemedia.blob.core.windows.net/media/Default/BlogPost/blog/cpu_individual.png)

**Tip:** You chart will scale to the largest counter value. This means that percent % counters that has highest value of 100 won't be very useful together with incremental counters that has no top limit.

## How to select counters ##
Open up perfmon searching from it in your start menu or press [Windows](Windows.md) + [R](R.md) and type perfmon.

![https://litemedia.blob.core.windows.net/media/Default/BlogPost/blog/perfmon_1.png](https://litemedia.blob.core.windows.net/media/Default/BlogPost/blog/perfmon_1.png)

If you press the plus sign, you will get the option to add performance counters to the gui. Here you will get a list of categories, counters and their instances that you may use in Alive.

![https://litemedia.blob.core.windows.net/media/Default/BlogPost/blog/perfmon_2.png](https://litemedia.blob.core.windows.net/media/Default/BlogPost/blog/perfmon_2.png)

## Default configuration ##
This is the default configuration that'll be applied when no configuration is in web.config.

```
<Alive>
  <counters>
    <groups>
      <group name="Hardware" updateLatency="1000">
        <counter 
          name="CPU" 
          categoryName="Processor Information"
          counterName = "% Processor Time"
          instanceName = "_Total" />
        <counter
          name="CPU#1"
          categoryName="Processor Information"
          counterName = "% Processor Time"
          instanceName = "0,0" />
        <counter
          name="CPU#2"
          categoryName="Processor Information"
          counterName = "% Processor Time"
          instanceName = "0,1" />
      </group>
      <group name="Memory" updateLatency="5000">
        <counter
          name="Memory %"
          categoryName="Memory"
          counterName="% Committed Bytes In Use" />
        <counter
          name="Paging File %"
          categoryName="Paging File"
          counterName="% Usage"
          instanceName="_Total" />
      </group>
      <group name="ASP.NET Requests" updateLatency="1000">
        <counter
          name="Queued"
          categoryName="ASP.NET"
          counterName="Requests Queued" />
      </group>
      <group name="Connections" updateLatency="5000">
        <counter
          name="SQL"
          categoryName="ASP.NET Applications"
          counterName="Session SQL Server connections total"
          instanceName="__Total__" />
        <counter
          name="State Server"
          categoryName="ASP.NET Applications"
          counterName="Session State Server connections total"
          instanceName="__Total__" />
      </group>
      <group name="Errors" updateLatency="5000">
        <counter
          name="Requests Failed"
          categoryName="ASP.NET Applications"
          counterName="Requests Failed"
          instanceName="__Total__" />
        <counter
          name="Exceptions"
          categoryName="ASP.NET Applications"
          counterName="Errors During Execution"
          instanceName="__Total__" />
        <counter
          name="Unhandled Exceptions"
          categoryName="ASP.NET Applications"
          counterName="Errors Unhandled During Execution"
          instanceName="__Total__" />
      </group>
    </groups>
  </counters>
</Alive>
```