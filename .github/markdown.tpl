<!-- https://github.com/aquasecurity/trivy/pull/3202 
    The author of this had a very similar use case to mine
    for outputting vulnerabilities to the action summary but not
    using the Advanced Security feature Github offers for dependency graphs.
    I'm surprised this isn't just part of the main templates shipped with
    trivy but I can't blame someone for not wanting to maintain markdown tables.
 -->
{{- if . }}
{{- range . }}
<h3>Target <code>{{ escapeXML .Target }}</code></h3>
{{- if (eq (len .Vulnerabilities) 0) }}
<h4>No Vulnerabilities found</h4>
{{- else }}
<h4>Vulnerabilities ({{ len .Vulnerabilities }})</h4>
<table>
    <tr>
        <th>Package</th>
        <th>ID</th>
        <th>Severity</th>
        <th>Installed Version</th>
        <th>Fixed Version</th>
    </tr>
    {{- range .Vulnerabilities }}
    <tr>
        <td><code>{{ escapeXML .PkgName }}</code></td>
        <td>{{ escapeXML .VulnerabilityID }}</td>
        <td>{{ escapeXML .Severity }}</td>
        <td>{{ escapeXML .InstalledVersion }}</td>
        <td>{{ escapeXML .FixedVersion }}</td>
    </tr>
    {{- end }}
</table>
{{- end }}
{{- if (eq (len .Misconfigurations ) 0) }}
<h4>No Misconfigurations found</h4>
{{- else }}
<h4>Misconfigurations</h4>
<table>
    <tr>
        <th>Type</th>
        <th>ID</th>
        <th>Check</th>
        <th>Severity</th>
        <th>Message</th>
    </tr>
    {{- range .Misconfigurations }}
    <tr>
        <td>{{ escapeXML .Type }}</td>
        <td>{{ escapeXML .ID }}</td>
        <td>{{ escapeXML .Title }}</td>
        <td>{{ escapeXML .Severity }}</td>
        <td>
          {{ escapeXML .Message }}
          <br><a href={{ escapeXML .PrimaryURL | printf "%q" }}>{{ escapeXML .PrimaryURL }}</a></br>
        </td>
    </tr>
    {{- end }}
</table>
{{- end }}
{{- end }}
{{- else }}
<h3>Trivy Returned Empty Report</h3>
{{- end }}