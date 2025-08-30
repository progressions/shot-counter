class AdminMailer < ApplicationMailer
  default from: 'system@chiwar.net'
  
  def blob_sequence_error(campaign, error_message)
    @campaign = campaign
    @error_message = error_message
    @timestamp = Time.current
    
    mail(
      to: 'progressions@gmail.com',
      subject: '[CRITICAL] Campaign Seeding Failed - Blob Sequence Error',
      priority: 'high'
    ) do |format|
      format.text { render plain: blob_error_text }
      format.html { render html: blob_error_html.html_safe }
    end
  end
  
  private
  
  def blob_error_text
    <<~TEXT
      CRITICAL ERROR: Campaign Seeding Failed
      
      Time: #{@timestamp}
      Campaign: #{@campaign&.name} (ID: #{@campaign&.id})
      User: #{@campaign&.user&.email}
      
      Error: Active Storage blob ID sequence conflict
      #{@error_message}
      
      IMMEDIATE ACTION REQUIRED:
      1. SSH into production: fly ssh console --app shot-counter
      2. Run: bundle exec rails db:fix_blob_sequence
      3. Then recreate the campaign or manually run seeding
      
      This error occurs when the blob ID sequence is out of sync after importing data.
      The sequence needs to be reset to MAX(id) + 1.
    TEXT
  end
  
  def blob_error_html
    <<~HTML
      <html>
        <body style="font-family: Arial, sans-serif; padding: 20px;">
          <h2 style="color: #dc3545;">CRITICAL ERROR: Campaign Seeding Failed</h2>
          
          <div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <p><strong>Time:</strong> #{@timestamp}</p>
            <p><strong>Campaign:</strong> #{@campaign&.name} (ID: #{@campaign&.id})</p>
            <p><strong>User:</strong> #{@campaign&.user&.email}</p>
          </div>
          
          <div style="background: #fff3cd; padding: 15px; border-radius: 5px; border-left: 4px solid #ffc107;">
            <h3>Error Details:</h3>
            <p>Active Storage blob ID sequence conflict</p>
            <pre style="background: #f1f1f1; padding: 10px; overflow-x: auto;">#{@error_message}</pre>
          </div>
          
          <div style="background: #d1ecf1; padding: 15px; border-radius: 5px; border-left: 4px solid #17a2b8; margin: 20px 0;">
            <h3>IMMEDIATE ACTION REQUIRED:</h3>
            <ol>
              <li>SSH into production: <code>fly ssh console --app shot-counter</code></li>
              <li>Run: <code>bundle exec rails db:fix_blob_sequence</code></li>
              <li>Then recreate the campaign or manually run seeding</li>
            </ol>
          </div>
          
          <p style="color: #6c757d; font-size: 14px;">
            This error occurs when the blob ID sequence is out of sync after importing data.
            The sequence needs to be reset to MAX(id) + 1.
          </p>
        </body>
      </html>
    HTML
  end
end